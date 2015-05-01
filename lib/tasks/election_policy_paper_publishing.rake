desc "Publishes policy papers that were converted from old-world policies."
task :publish_post_election_policy_papers => :environment do
  mapping_csv_path = Rails.root+"lib/tasks/election/2015-04-20-13-42-38-policy_paper_creation_output.csv"
  policy_paper_ids = CSV.parse(File.open(mapping_csv_path).read, headers: true).map do |row|
    row["policy_paper_id"]
  end

  require_relative "election/policy_paper_publisher"
  Election::PolicyPaperPublisher.new(policy_paper_ids).run!
end
