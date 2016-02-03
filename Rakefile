CARTHAGE_VERSION = '0.11.0'
XCODE_VERSION = '9548.1'
XCODE_SHORT_VERSION = '7.2.1'

desc 'Build the project’s dependencies'
task :bootstrap => [:check_tools, :clean] do
  system 'carthage bootstrap --platform iOS --no-use-binaries'
  system 'git submodule update --init --recursive'
  system 'cd Vendor/CanvasKit && carthage bootstrap --platform iOS --no-use-binaries'
end

desc 'Update the project’s dependencies.'
task :update => :check_tools do
  system 'carthage update --no-build'
  Rake::Task['bootstrap'].invoke
end

# TODO: This could be a lot more robust, but should at least help for now.
desc 'Check for required tools.'
task :check_tools do
  next if ENV['SKIP_TOOLS_CHECK']

  # Check for Xcode
  unless path = `xcode-select -p`.chomp
    fail "Xcode is not installed. Please install Xcode #{XCODE_SHORT_VERSION} from https://developer.apple.com/xcode/download"
  end

  # Check Xcode version
  info_path = File.expand_path path + '/../Info'
  unless (version = `defaults read #{info_path} CFBundleVersion`.chomp) == XCODE_VERSION
    fail "Xcode #{version} is installed. Xcode #{XCODE_VERSION} was expected. Please install Xcode #{XCODE_SHORT_VERSION} from https://developer.apple.com/xcode/download"
  end

  # Check Carthage
  unless (version = `carthage version`.chomp) == CARTHAGE_VERSION
    fail "Carthage #{CARTHAGE_VERSION} isnt’t installed."
  end
end

desc 'Clean Carthage'
task :clean do
  system 'rm -rf Carthage'
  system 'rm -rf Vendor/CanvasKit/Carthage'
end

private

def fail(s)
  puts s
  raise 'ToolsMissing'
end
