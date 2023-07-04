# Auto-generated file, DO NOT EDIT
# Source: release/cockroach-sql-tmpl.rb

class CockroachSql < Formula
  desc "Distributed SQL database shell"
  homepage "https://www.cockroachlabs.com"
  version "23.1.4"
  on_macos do
    on_intel do
      url "https://binaries.cockroachdb.com/cockroach-sql-v23.1.4.darwin-10.9-amd64.tgz"
      sha256 "7d4f56c90e3385560ca929cc5f45434718f5837a222f0e5b3b16b9211ddddfa5"
    end
    on_arm do
      url "https://binaries.cockroachdb.com/cockroach-sql-v23.1.4.darwin-11.0-arm64.tgz"
      sha256 "7ceb52c10113955c54d43c7d523297a2e38d5457109b3da8cd9d944e4b803cba"
    end
  end

  on_linux do
    on_intel do
      url "https://binaries.cockroachdb.com/cockroach-sql-v23.1.4.linux-amd64.tgz"
      sha256 "b05c3630ab77cfcdbd6a6dc09e96bbae2fc5004ba77797590b21d1c53e61caee"
    end
    on_arm do
      url "https://binaries.cockroachdb.com/cockroach-sql-v23.1.4.linux-arm64.tgz"
      sha256 "5691e74bfb0351653d8d11b26774391133849f04ba1347ea23bb26f7dda525f8"
    end
  end  

  def install
    bin.install "cockroach-sql"
  end

  test do
    output = shell_output("#{bin}/cockroach-sql --version", 0)
    assert_match "23.1.4", output
  end

end

