# frozen_string_literal: true

require "bundler/setup"
require "rspec/core/rake_task"
require "yard"

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ["lib/**/*.rb"]
  t.options = ["--no-private"]
end

task default: [:spec]
