module Election
  class PolicyPaperPublisher
    def initialize(policy_paper_ids)
      @policy_paper_ids = policy_paper_ids
    end

    def run!
      policy_papers = Publication.find(@policy_paper_ids)

      policy_papers.each do |policy_paper|
        policy_paper.minor_change = true
        policy_paper.major_change_published_at = policy_paper.first_published_at
        policy_paper.force_publish!
      end
    end
  end
end
