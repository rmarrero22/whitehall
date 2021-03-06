WorldwideOffice.all.each do |office|
  unless ["Embassy", "Consulate", "High Commission"].include?(office.worldwide_office_type.name)
    case office.slug
    when /^british\-embassy/
      if office.update_attribute(:worldwide_office_type, WorldwideOfficeType::Embassy)
        puts "Updated #{office.slug} to type WorldwideOfficeType::Embassy"
      end
    when /^british\-high\-commission/
      if office.update_attribute(:worldwide_office_type, WorldwideOfficeType::HighCommission)
        puts "Updated #{office.slug} to type WorldwideOfficeType::HighCommission"
      end
    when /^british\-consulate/
      if office.update_attribute(:worldwide_office_type, WorldwideOfficeType::Consulate)
        puts "Updated #{office.slug} to type WorldwideOfficeType::Consulate"
      end
    end
  end
end
