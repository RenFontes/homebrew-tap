# Auto-generated file, DO NOT EDIT
# Source: release/cockroach-tmpl.rb

class Cockroach < Formula
  desc "Distributed SQL database"
  homepage "https://www.cockroachlabs.com"
  version "23.1.4"
  on_macos do
    on_intel do
      url "https://binaries.cockroachdb.com/cockroach-v23.1.4.darwin-10.9-amd64.tgz"
      sha256 "019452db12dbef985f16fa958c44d679aa81c7e7826aa7e03cbfbb76c95c8844"
    end
    on_arm do
      url "https://binaries.cockroachdb.com/cockroach-v23.1.4.darwin-11.0-arm64.tgz"
      sha256 "d0a136d159fba61aa7b90ba37ad757b3f016996302f6c8d55b2cd3e3aa60f481"
    end
  end

  on_linux do
    on_x86_64 do
      url "https://binaries.cockroachdb.com/cockroach-v23.1.4.linux-amd64.tgz"
      sha256 "3125f85389c81bd4d443cb6e826ccbdd8eb4a49ef2d397f95bdb2e3bd6e79acb"
    end
    on_arm do
      url "https://binaries.cockroachdb.com/cockroach-v23.1.4.linux-arm64.tgz"
      sha256 "3c720836a693deb2955eeee39ca8433f4f165eec5660c82456b1f0046ad78e6d"
    end
  end  

  def install
    bin.install "cockroach"
    on_intel do
      lib.mkpath
      mkdir "#{lib}/cockroach"
      lib.install "lib/libgeos.dylib" => "cockroach/libgeos.dylib"
      lib.install "lib/libgeos_c.dylib" => "cockroach/libgeos_c.dylib"

      # Brew sets rpaths appropriately, but only if the rpaths are set
      # to not include "@rpath". As such, use the #{lib} location for the
      # rpaths.
      system "install_name_tool", "-id",
        "#{lib}/cockroach/libgeos.dylib", "#{lib}/cockroach/libgeos.dylib"
      system "install_name_tool", "-id",
        "#{lib}/cockroach/libgeos_c.1.dylib", "#{lib}/cockroach/libgeos_c.dylib"
      system "install_name_tool", "-change",
        "@rpath/libgeos.3.8.1.dylib", "#{lib}/cockroach/libgeos.dylib",
        "#{lib}/cockroach/libgeos_c.dylib"
    end

    system "#{bin}/cockroach", "gen", "man", "--path=#{man1}"

    bash_completion.mkpath
    system "#{bin}/cockroach", "gen", "autocomplete", "bash", "--out=#{bash_completion}/cockroach"

    zsh_completion.mkpath
    system "#{bin}/cockroach", "gen", "autocomplete", "zsh", "--out=#{zsh_completion}/_cockroach"
  end

  def caveats; <<~EOS
    For local development only, this formula ships a launchd configuration to
    start a single-node cluster that stores its data under:
      #{var}/cockroach/
    Instead of the default port of 8080, the node serves its admin UI at:
      #{Formatter.url("http://localhost:26256")}

    Do NOT use this cluster to store data you care about; it runs in insecure
    mode and may expose data publicly in e.g. a DNS rebinding attack. To run
    CockroachDB securely, please see:
      #{Formatter.url("https://www.cockroachlabs.com/docs/stable/secure-a-cluster.html")}
  EOS
  end

  service do
    args = [
      "start-single-node",
      "--store=#{var}/cockroach",
      "--http-port=26256",
      "--insecure",
      "--host=localhost",
     ]
    if !(OS.mac? && Hardware::CPU.arm?)
      args << "--spatial-libs=#{opt_bin}/../lib/cockroach"
    end
    run [opt_bin/"cockroach"] + args
    working_dir var
    keep_alive true
    log_path var/"log/cockroach.log"
    error_log_path var/"log/cockroach.err"
  end

  test do
    begin
      # Redirect stdout and stderr to a file, or else  `brew test --verbose`
      # will hang forever as it waits for stdout and stderr to close.
      pid = fork do
        exec "#{bin}/cockroach start-single-node --insecure --background --listen-addr=127.0.0.1:0 --http-addr=127.0.0.1:0 --listening-url-file=listen_url_fifo &> start.out"
      end
      sleep 20

      # TODO(bdarnell): remove the X from this variable and the --url flags after
      # https://github.com/cockroachdb/cockroach/issues/40747 is fixed.
      ENV["XCOCKROACH_URL"] = File.read("listen_url_fifo").strip
      pipe_output("#{bin}/cockroach sql --url=$XCOCKROACH_URL", <<~EOS)
        CREATE DATABASE bank;
        CREATE TABLE bank.accounts (id INT PRIMARY KEY, balance DECIMAL);
        INSERT INTO bank.accounts VALUES (1, 1000.50);
      EOS
      output = pipe_output("#{bin}/cockroach sql --url=$XCOCKROACH_URL --format=csv",
        "SELECT * FROM bank.accounts;")
      assert_equal <<~EOS, output
        id,balance
        1,1000.50
      EOS
      if !(OS.mac? && Hardware::CPU.arm?)
        output = pipe_output("#{bin}/cockroach sql --url=$XCOCKROACH_URL --format=csv",
          "SELECT ST_IsValid(ST_MakePoint(1, 1)) is_valid;")
        assert_equal <<~EOS, output
          is_valid
          t
        EOS
      end
    rescue => e
      # If an error occurs, attempt to print out any messages from the
      # server.
      begin
        $stderr.puts "server messages:", File.read("start.out")
      rescue
        $stderr.puts "unable to load messages from start.out"
      end
      raise e
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end

