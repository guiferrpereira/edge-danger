require 'open-uri'
require 'net/http'

module Utils
  def self.code_coverage_markup(results, master_results)
    message = "```diff\n@@           Coverage Diff           @@\n"
    message << "##           master       ##{ENV['CIRCLE_PULL_REQUEST'].split('/').last}   +/-   ##\n"
    message << "=======================================\n"
    message << add_line('Coverage', results.dig(:metrics, :covered_percent), master_results ? master_results.dig(:metrics, :covered_percent) : nil, '%')
    message << "=======================================\n"
    message << add_line('Files', results.dig(:files)&.count, master_results ? master_results.dig(:files)&.count : nil)
    message << add_line('Lines', results.dig(:metrics, :total_lines), master_results ? master_results.dig(:metrics, :total_lines) : nil)
    message << "=======================================\n"
    message << add_line('Misses', results.dig(:metrics, :total_lines) + results.dig(:metrics, :covered_lines), master_results ? (master_results.dig(:metrics, :total_lines) - master_results.dig(:metrics, :covered_lines)) : nil)
    message << "```"
  end

  def self.code_coverage_report(artifact_url)
    artifacts = JSON.parse(URI.parse(artifact_url).read).map { |a| a['url'] }

    coverage_url = artifacts.find { |artifact| artifact.end_with?('coverage/coverage.json') }

    return nil if !coverage_url

    uri = URI.parse("#{coverage_url}?circle-token=#{ENV['CIRCLE_TOKEN']}")

    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body)
  end

  private

  def self.add_line(title, current, latest, symbol=nil)
    return "  #{title}   #{justify_text('-', 6)}#{justify_text(current.to_s + symbol.to_s, 9)}\n" if !latest

    "  #{title}   #{justify_text(latest.to_s + symbol.to_s, 6)}#{justify_text(current.to_s + symbol.to_s, 9)}\n"
  end

  def self.justify_text(string, adjust)
    adjust = string.length + adjust

    string.rjust(adjust - string.length)
  end
end

fail('Please provide a summary in the PR description') if (github.pr_body || '').length < 5

warn(':exclamation: Big PR') if git.lines_of_code > 500

warn('Please rebase to get rid of the merge commits in this PR') if git.commits.any? { |c| c.message =~ /^Merge branch 'master'/ }

warn('PR base is not set to master!') if !github.branch_for_base.include?('master')

# PR title consistency
warn("Title of PR should start with [EDG-$JIRA_ISSUE_NUMBER]") if !github.pr_title.match(/\[EDG-\d*\]\s/)

# Don't let testing shortcuts get into master by accident
if Dir.exist?('spec')
  warn('fdescribe left in tests') if `grep -r -e '\\bfdescribe\\b' spec/ |grep -v 'danger ok' `.length > 1
  warn('fcontext left in tests') if `grep -r -e '\\bfcontext\\b' spec/ |grep -v 'danger ok' `.length > 1
  warn('fit left in tests') if `grep -r -e '\\bfit\\b' spec/ | grep -v 'danger ok' `.length > 1
  warn('ap left in tests') if `grep -r -e '\\bap\\b' spec/ | grep -v 'danger ok' `.length > 1
  warn('puts left in tests') if `grep -r -e '\\bputs\\b' spec/ | grep -v 'danger ok' `.length > 1
end

if ENV['CIRCLE_TOKEN']
  # current pr coverage
  results = Utils.code_coverage_report("https://circleci.com/api/v1.1/project/github/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/#{ENV['CIRCLE_BUILD_NUM']}/artifacts?circle-token=#{ENV['CIRCLE_TOKEN']}")

  # master coverage
  master_results = Utils.code_coverage_report("https://circleci.com/api/v1.1/project/github/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/latest/artifacts?circle-token=#{ENV['CIRCLE_TOKEN']}&branch=master")

  markdown Utils.code_coverage_markup(results.with_indifferent_access, master_results.with_indifferent_access)

  if master_results && master_results['metrics']['covered_percent'].round(2)  > results['metrics']['covered_percent'].round(2)
    warn("Code coverage decreased from #{master_results['metrics']['covered_percent'].round(2).to_s}% to #{results['metrics']['covered_percent'].round(2)}%")
  end
end
