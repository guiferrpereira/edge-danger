danger.import_plugin('https://raw.githubusercontent.com/guiferrpereira/danger-rcov/master/lib/rcov/plugin.rb')

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
  markdown rcov.report(
    current_url: "https://circleci.com/api/v1.1/project/github/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/#{ENV['CIRCLE_BUILD_NUM']}/artifacts?circle-token=#{ENV['CIRCLE_TOKEN']}",
    master_url: "https://circleci.com/api/v1.1/project/github/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/latest/artifacts?circle-token=#{ENV['CIRCLE_TOKEN']}&branch=master"
  )

  if master_results && master_results['metrics']['covered_percent'].round(2)  > results['metrics']['covered_percent'].round(2)
    warn("Code coverage decreased from #{master_results['metrics']['covered_percent'].round(2).to_s}% to #{results['metrics']['covered_percent'].round(2)}%")
  end
end
