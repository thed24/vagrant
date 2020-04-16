module Vagrant
  module Util
    # Generic installation of content to shell config file
    class InstallShellConfig
      PREPEND = "".freeze
      STRING_INSERT = "".freeze
      APPEND = "".freeze
      CONFIG_PATHS = [""].freeze

      def self.shell_installed(home)
        self::CONFIG_PATHS.each do |path|
          config_file = File.join(home, path)
          if File.exists?(config_file)
            return config_file
          end
        end
        return nil
      end

      def self.is_installed(path)
        File.foreach(path) do |line|
          if line.include?(self::PREPEND)
            return true
          end
        end
        return false
      end

      def self.install(home)
        path = shell_installed(home)
        if path && !is_installed(path)
          File.open(path, "a") do |f|
            f.write("\n")
            f.write(self::PREPEND)
            f.write("\n")
            f.write(self::STRING_INSERT)
            f.write("\n")
            f.write(self::APPEND)
            f.write("\n")
          end
        end
        return path
      end
    end

    # Install autocomplete script to zsh config located as .zshrc
    class InstallZSHShellConfig < InstallShellConfig
      PREPEND = "# >>>> Vagrant zsh completion (start)".freeze
      STRING_INSERT = """fpath=(#{File.join(Vagrant.source_root, "contrib", "zsh")} $fpath)\ncompinit""".freeze
      APPEND = "# <<<<  Vagrant zsh completion (end)".freeze
      CONFIG_PATHS = [".zshrc"].freeze
    end

    # Install autocomplete script to bash config located as .bashrc or .bash_profile
    class InstallBashShellConfig < InstallShellConfig
      PREPEND = "# >>>> Vagrant bash completion (start)".freeze
      STRING_INSERT = ". #{File.join(Vagrant.source_root, 'contrib', 'bash', 'completion.sh')}".freeze
      APPEND = "# <<<<  Vagrant bash completion (end)".freeze
      CONFIG_PATHS = [".bashrc", ".bash_profile"].freeze
    end

    # Install autocomplete script for supported shells
    class InstallCLIAutocomplete
      SUPPORTED_SHELLS = {
        "zsh" => Vagrant::Util::InstallZSHShellConfig,
        "bash" => Vagrant::Util::InstallBashShellConfig
      }

      def self.install
        home = Dir.home
        written_paths = []
        SUPPORTED_SHELLS.each do |k, shell|
          p = shell.install(home)
          if p
            written_paths.push(p)
          end
        end
        return written_paths
      end
    end
  end
end
