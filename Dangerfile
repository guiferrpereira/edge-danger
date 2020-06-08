# TODO - this will move to a gem

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

def string_helper(string, adjust)
  adjust = string.length + adjust

  string.rjust(adjust - string.length)
end

def code_coverage_report(artifact_url)
  artifacts = JSON.parse(URI.parse(artifact_url).read).map { |a| a['url'] }

  coverage_url = artifacts.find { |artifact| artifact.end_with?('coverage/coverage.json') }

  return nil if !coverage_url

  uri = URI.parse("#{coverage_url}?circle-token=#{ENV['CIRCLE_TOKEN']}")

  response = Net::HTTP.get_response(uri)

  JSON.parse(response.body)
end

def code_coverage_markup(results, master_results)
  message = "```diff\n@@           Coverage Diff           @@\n"
  message << "##           master       ##{ENV['CIRCLE_PULL_REQUEST'].split('/').last}   +/-   ##\n"
  message << "=======================================\n"
  message << "  Coverage   " + string_helper("#{master_results ? master_results['metrics']['covered_percent'].round(2).to_s + '%' : '-'}", 6) + string_helper("#{results['metrics']['covered_percent'].round(2)}%", 9) + "\n"
  message << "=======================================\n"
  message << "  Files      " + string_helper("#{master_results ? master_results['files']&.count : '-'}", 6) + string_helper("#{results['files']&.count}", 9) + "\n"
  message << "  Lines      " + string_helper("#{master_results ? master_results['metrics']['total_lines'] : '-'}", 6) + string_helper("#{results['metrics']['total_lines']}", 9) + "\n"
  message << "=======================================\n"
  message << "  Hits       " + string_helper("#{master_results ? master_results['metrics']['covered_lines'] : '-'}", 6) + string_helper("#{results['metrics']['covered_lines']}", 9) + "\n"
  message << "  Misses     " + string_helper("#{master_results ? master_results['metrics']['total_lines'] - results['metrics']['covered_lines'] : '-'}", 6) + string_helper("#{results['metrics']['total_lines'] - results['metrics']['covered_lines']}", 9) + "\n```"
  message
end

if ENV['CIRCLE_TOKEN']
  require 'open-uri'
  require 'net/http'

  # current pr coverage
  results = code_coverage_report("https://circleci.com/api/v1.1/project/github/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/#{ENV['CIRCLE_BUILD_NUM']}/artifacts?circle-token=#{ENV['CIRCLE_TOKEN']}")

  # master coverage
  master_results = code_coverage_report("https://circleci.com/api/v1.1/project/github/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/latest/artifacts?circle-token=#{ENV['CIRCLE_TOKEN']}&branch=master")

  markdown code_coverage_markup(results, master_results)

  if master_results && master_results['metrics']['covered_percent'].round(2)  > results['metrics']['covered_percent'].round(2)
    warn("Code coverage decreased from #{master_results['metrics']['covered_percent'].round(2).to_s}% to #{results['metrics']['covered_percent'].round(2)}%")
  end
end
