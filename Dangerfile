danger.import_plugin('https://raw.githubusercontent.com/guiferrpereira/danger-rcov/master/lib/rcov/plugin.rb')

require 'open-uri'
require 'net/http'

module Utils
  def self.code_coverage_markup(results, master_results)
    @current_covered_percent = results.dig('metrics', 'covered_percent').round(2)
    @current_files_count = results.dig('files')&.count
    @current_total_lines = results.dig('metrics', 'total_lines')
    @current_misses_count = @current_total_lines - results.dig('metrics', 'covered_lines')

    if master_results
      @master_covered_percent = master_results.dig('metrics', 'covered_percent').round(2)
      @master_files_count = master_results.dig('files')&.count
      @master_total_lines = master_results.dig('metrics', 'total_lines')
      @master_misses_count = @master_total_lines - master_results.dig('metrics', 'covered_lines')
    end

    message = "```diff\n@@           Coverage Diff            @@\n"
    message << "## #{justify_text('master', 16)} #{justify_text('#' + ENV['CIRCLE_PULL_REQUEST'].split('/').last, 8)} #{justify_text('+/-', 7)} #{justify_text('##', 3)}\n"
    message << separator_line
    message << new_line('Coverage', @current_covered_percent, @master_covered_percent, '%')
    message << separator_line
    message << new_line('Files', @current_files_count, @master_files_count)
    message << new_line('Lines', @current_total_lines, @master_total_lines)
    message << separator_line
    message << new_line('Misses', @current_misses_count, @master_misses_count)
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

  def self.separator_line
    "========================================\n"
  end

  def self.new_line(title, current, master, symbol=nil)
    formatter = symbol ? '%+.2f' : '%+d'
    currrent_formatted = current.to_s + symbol.to_s
    master_formatted = master ? master.to_s + symbol.to_s : '-'
    prep = (master_formatted != '-' && current - master != 0) ? '+ ' : '  '

    line = data_string(title, master_formatted, currrent_formatted, prep)
    line << justify_text(sprintf(formatter, current - master) + symbol.to_s, 8) if prep == '+ '
    line << "\n"
    line
  end

  def self.justify_text(string, adjust, position='right')
    string.send(position == 'right' ? :rjust : :ljust, adjust)
  end

  def self.data_string(title, master, current, prep)
    "#{prep}#{justify_text(title, 9, 'left')} #{justify_text(master, 7)}#{justify_text(current, 9)}"
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

  markdown rcov.report(results, master_results)

  if master_results && master_results['metrics']['covered_percent'].round(2)  > results['metrics']['covered_percent'].round(2)
    warn("Code coverage decreased from #{master_results['metrics']['covered_percent'].round(2).to_s}% to #{results['metrics']['covered_percent'].round(2)}%")
  end
end
