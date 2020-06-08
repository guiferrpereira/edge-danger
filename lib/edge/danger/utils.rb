module Edge
  module Danger
    class Utils
      def self.code_coverage_markup(results, master_results)
        message = "```diff\n@@           Coverage Diff           @@\n"
        message << "##           master       ##{ENV['CIRCLE_PULL_REQUEST'].split('/').last}   +/-   ##\n"
        message << "=======================================\n"
        message << "  Coverage   " + justify_text("#{master_results ? master_results['metrics']['covered_percent'].round(2).to_s + '%' : '-'}", 6) + justify_text("#{results['metrics']['covered_percent'].round(2)}%", 9) + "\n"
        message << "=======================================\n"
        message << "  Files      " + justify_text("#{master_results ? master_results['files']&.count : '-'}", 6) + justify_text("#{results['files']&.count}", 9) + "\n"
        message << "  Lines      " + justify_text("#{master_results ? master_results['metrics']['total_lines'] : '-'}", 6) + justify_text("#{results['metrics']['total_lines']}", 9) + "\n"
        message << "=======================================\n"
        message << "  + Hits       " + justify_text("#{master_results ? master_results['metrics']['covered_lines'] : '-'}", 6) + justify_text("#{results['metrics']['covered_lines']}", 9) + " +1 \n"
        message << "  + Misses     " + justify_text("#{master_results ? master_results['metrics']['total_lines'] - results['metrics']['covered_lines'] : '-'}", 6) + justify_text("#{results['metrics']['total_lines'] - results['metrics']['covered_lines']}", 9) + " -1 \n```"
        message
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

      def self.justify_text(string, adjust)
        adjust = string.length + adjust

        string.rjust(adjust - string.length)
      end
    end
  end
end


