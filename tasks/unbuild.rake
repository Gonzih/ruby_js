
namespace :unbuild do
  task :run do
    if File.exists?('lib')
      sh %{rm -rf lib}
      !File.exists?('lib')
    end
  end
end

desc "Removes the build (./lib)"
task :unbuild => "unbuild:run"
