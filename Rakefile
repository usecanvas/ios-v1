# frozen_string_literal: true

CARTHAGE_VERSION = '0.17.2'
XCODE_VERSION = '10188.1'
XCODE_SHORT_VERSION = '7.3.1 (7D1014)'
XCODE_URL = 'https://itunes.apple.com/app/xcode/id497799835'
PLATFORM = 'ios'

SENTRY_API_KEY = '3c95c860602c4859984fa75d63b3dc83'
SENTRY_ORG = 'usecanvas'
SENTRY_PROJECT = 'ios'

class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
end

desc 'Build the project’s dependencies'
task :bootstrap do
  Rake::Task['check_tools'].invoke unless ENV['SKIP_TOOLS_CHECK']
  info "Getting Carthage dependencies…"
  system "carthage bootstrap --platform #{PLATFORM}"
  success "You're ready to go! Open Canvas.xcodeproj and click ▶"
end

desc 'Update the project’s dependencies.'
task :update => :check_tools do
  info "Updating Carthage dependencies…"
  system "carthage update --platform #{PLATFORM}"
end

# TODO: This could be a lot more robust, but should at least help for now.
desc 'Check for required tools.'
task :check_tools do
  next if ENV['SKIP_TOOLS_CHECK']

  # Check for Xcode
  unless path = `xcode-select -p`.chomp
    fail "Xcode is not installed. Please install Xcode #{XCODE_SHORT_VERSION} from #{XCODE_URL}"
  end

  # Check Xcode version
  info_path = File.expand_path path + '/../Info'
  unless (version = `defaults read #{info_path} CFBundleVersion`.chomp) == XCODE_VERSION
    fail "Xcode #{version} is installed. Xcode #{XCODE_VERSION} was expected. Please install Xcode #{XCODE_SHORT_VERSION} from #{XCODE_URL}"
  end

  # Check Carthage
  unless (version = `carthage version`.chomp) == CARTHAGE_VERSION
    fail "Carthage #{CARTHAGE_VERSION} isnt’t installed. You can install with `brew install carthage`. You may need to update Homebrew with `brew update` first."
  end
end

desc 'Clean Carthage dependencies'
task :clean do
  info "Cleaning development dependencies…"

  # Remove build directory symlinks
  Dir['Carthage/Checkouts/*'].each do |path|
    next unless File.symlink?(path)
    build_dir = "#{path}/Carthage/Build"
    if File.symlink?(build_dir)
      system "rm -f #{build_dir}"
    end
  end

  # Remove workspace
  system 'rm -rf Canvas.xcworkspace'

  info "Cleaning Carthage dependencies…"
  system 'rm -rf Carthage'

  success "Clean!"
end

desc 'Put a first-party dependency into development mode'
task :develop, [:name] do |t, args|
  names = [args[:name]] + args.extras

  dependencies_xml = %Q{    <FileRef location="group:Canvas.xcodeproj"></FileRef>\n}

  names.each do |name|
    source_dir = "../#{name}"
    checkout_dir = "Carthage/Checkouts/#{name}"

    # Setup symlink
    info "Creating symlink for #{name}…"
    system "rm -rf #{checkout_dir}"

    unless File.exists?(source_dir)
      fail "#{name} is missing at `#{source_dir}`"
    end

    # Get ref
    begin
      resolved = File.read('Cartfile.resolved')
    rescue
      fail 'Failed to read Cartfile.resolved.'
    end


    unless matches = resolved.match(/git(?:hub)? ".*\/#{name}" "(.*)"/) and ref = matches[1]
      fail "Failed to find #{name} in Cartfile.resolved."
    end

    system 'mkdir -p Carthage/Checkouts'
    system "ln -s ../../#{source_dir} #{checkout_dir}"

    # Update git
    info "Checking out #{name} at #{ref}…"
    system "cd #{source_dir} && git fetch --quiet && git checkout --quiet #{ref}"

    # Symlink build directory
    system "mkdir -p #{checkout_dir}/Carthage/Build/"
    build_dir = "#{checkout_dir}/Carthage/Build"
    system "rm -rf #{build_dir}"
    system "ln -s `pwd`/Carthage/Build #{build_dir}"

    dependencies_xml += %Q{    <FileRef location="group:Carthage/Checkouts/#{name}/#{name}.xcodeproj"></FileRef>\n}
  end

  # Setup workspace
  info 'Creating `Canvas.xcworkspace`…'
  system 'rm -rf Canvas.xcworkspace'
  system 'mkdir Canvas.xcworkspace'

  File.open 'Canvas.xcworkspace/contents.xcworkspacedata', 'w' do |file|
    file.write %Q{<?xml version="1.0" encoding="UTF-8"?>\n<Workspace version="1.0">\n#{dependencies_xml}</Workspace>\n}
  end

  success "Setup `Canvas.xcworkspace` for developing #{names.join(', ')}!"
end

namespace :sentry do
  desc 'Upload dSYM files to Sentry'
  task :upload do
    unless path = `which sentry-cli`.chomp
      fail "sentry-cli is not installed. Please install from https://github.com/getsentry/sentry-cli"
    end

    unless directory = ENV['DSYM_DIRECTORY']
      fail "Usage: DSYM_DIRECTORY=some_path rake sentry:upload"
    end

    dsym_paths = Dir["#{directory}/*.dSYM"]
    fail "No dSYM files found." if dsym_paths.length == 0

    dsym_paths.each do |path|
      system %(sentry-cli --api-key #{SENTRY_API_KEY} upload-dsym "#{path}" --org #{SENTRY_ORG} --project #{SENTRY_PROJECT})
    end
  end
end

private

def info(s)
  puts s.bold.blue
end

def success(s)
  puts s.bold.green
end

def fail(s)
  abort s.bold.red
end
