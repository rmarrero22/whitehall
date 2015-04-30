namespace :election do
  desc "Republishes all case studies to the Publishing API"
  task :republish_case_studies => :environment do
    require 'data_hygiene/publishing_api_republisher'

    DataHygiene::PublishingApiRepublisher.new(CaseStudy.published).perform
  end

  desc "Creates the associations between all editions and new/future policies, based on their existing policy relations"
  task :migrate_old_policy_taggings_to_new => :environment do
    require 'data_hygiene/future_policy_tagging_migrator'

    edition_scope = Edition.
                      where(type: policy_taggable_edition_classes).
                      where(state: editable_edition_states).
                      includes(related_policies: :related_documents)

    DataHygiene::FuturePolicyTaggingMigrator.new(edition_scope, Logger.new(STDOUT)).migrate!
  end

  desc "Will register redirects for all policies and remove them from rummager based on the information in data/policy_redircts.csv"
  task :redirect_policies do
    require 'gds_api/router'
    require 'csv'

    router = GdsApi::Router.new(Plek.find('router-api'))
    rummager_index = Rummageable::Index.new(Plek.find('search'), '/government', logger: Rails.logger)

    CSV.foreach(Rails.root.join('data/policy_redirects.csv'), headers: true) do |row|
      source, destination = row['source'], row['destination']

      if destination.blank?
        puts "GONE route for #{source}"
        router.add_gone_route(source, :exact)
      else
        puts "Redirecting #{source} to #{destination}"
        router.add_redirect_route(source, :exact, destination)
      end

      rummager_index.delete(source)
    end

    router.commit_routes
  end

private

  def editable_edition_states
    Edition.state_machine.states.map(&:name) - [:superseded, :deleted, :archived]
  end

  def policy_taggable_edition_classes
    Whitehall.edition_classes.select { |klass| klass.ancestors.include?(Edition::RelatedPolicies) }
  end
end
