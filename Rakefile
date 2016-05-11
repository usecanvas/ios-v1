# frozen_string_literal: true

CARTHAGE_VERSION = '0.16.2'
XCODE_VERSION = '10188.1'
XCODE_SHORT_VERSION = '7.3.1 (7D1014)'
XCODE_URL = 'https://itunes.apple.com/app/xcode/id497799835'

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
task :bootstrap => [:clean] do
  Rake::Task['check_tools'].invoke unless ENV['SKIP_TOOLS_CHECK']
  puts "Getting Carthage dependencies…".bold.blue
  system 'carthage bootstrap --platform iOS --no-use-binaries'

  puts "\nGetting git dependencies…".bold.blue
  system 'git submodule update --init'

  puts "\nYou're ready to go! Open Canvas.xcodeproj and click ▶".bold.green
end

desc 'Update the project’s dependencies.'
task :update => :check_tools do
  puts "Updating Carthage dependencies…".bold.blue
  system 'carthage update --no-build'
  Rake::Task['bootstrap'].invoke
end

# TODO: This could be a lot more robust, but should at least help for now.
desc 'Check for required tools.'
task :check_tools do
  next if ENV['SKIP_TOOLS_CHECK']

  # Check for Xcode
  unless path = `xcode-select -p`.chomp
    abort "Xcode is not installed. Please install Xcode #{XCODE_SHORT_VERSION} from #{XCODE_URL}".bold.red
  end

  # Check Xcode version
  info_path = File.expand_path path + '/../Info'
  unless (version = `defaults read #{info_path} CFBundleVersion`.chomp) == XCODE_VERSION
    abort "Xcode #{version} is installed. Xcode #{XCODE_VERSION} was expected. Please install Xcode #{XCODE_SHORT_VERSION} from #{XCODE_URL}".bold.red
  end

  # Check Carthage
  unless (version = `carthage version`.chomp) == CARTHAGE_VERSION
    abort "Carthage #{CARTHAGE_VERSION} isnt’t installed. You can install with `brew install carthage`. You may need to update Homebrew with `brew update` first.".bold.red
  end
end

desc 'Clean Carthage'
task :clean do
  puts "Cleaning Carthage dependencies…".bold.blue
  system 'rm -rf Carthage'
end

namespace :sentry do
  desc 'Upload dSYM files to Sentry'
  task :upload do
    unless path = `which sentry-cli`.chomp
      abort "sentry-cli is not installed. Please install from https://github.com/getsentry/sentry-cli"
    end

    unless directory = ENV['DSYM_DIRECTORY']
      abort "Usage: DSYM_DIRECTORY=some_path rake sentry:upload"
    end

    dsym_paths = Dir["#{directory}/*.dSYM"]
    abort "No dSYM files found." if dsym_paths.length == 0

    dsym_paths.each do |path|
      system %(sentry-cli --api-key #{SENTRY_API_KEY} upload-dsym "#{path}" --org #{SENTRY_ORG} --project #{SENTRY_PROJECT})
    end
  end
end

