class AbbacusCortex < Formula
  desc "AI knowledge pipeline -- capture, search, and reason over your knowledge"
  homepage "https://github.com/abbacusgroup/Cortex"
  url "https://files.pythonhosted.org/packages/source/a/abbacus-cortex/abbacus_cortex-0.3.0.tar.gz"
  sha256 "2c0fbfb67190beb03ca9b426dd825a55d45c6b63208b1161444e5f44b77551ea"
  license "MIT"

  depends_on "python@3.12"

  def install
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install_and_link buildpath
  end

  def post_install
    (var/"cortex").mkpath
    (var/"log/cortex").mkpath
  end

  def caveats
    <<~EOS
      To start the Cortex MCP server as a background service:
        brew services start abbacus-cortex

      Or run manually:
        cortex serve --transport mcp-http

      Initialize Cortex (first time only):
        cortex setup

      For semantic search, install the embeddings extra:
        #{libexec}/bin/pip install sentence-transformers

      Or configure an API-based embedding provider:
        export CORTEX_EMBEDDING_PROVIDER=litellm
        export CORTEX_EMBEDDING_MODEL=openai/text-embedding-3-small
        export CORTEX_EMBEDDING_API_KEY=sk-...
    EOS
  end

  service do
    run [opt_bin/"cortex", "serve", "--transport", "mcp-http",
         "--host", "127.0.0.1", "--port", "1314"]
    keep_alive true
    log_path var/"log/cortex/mcp.log"
    error_log_path var/"log/cortex/mcp.err"
    working_dir var/"cortex"
  end

  test do
    system bin/"cortex", "--help"
  end
end
