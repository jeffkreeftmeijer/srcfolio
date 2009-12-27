Given /^a contributor exists with a login of "([^\"]*)" and a name of "([^\"]*)"$/ do |login, name|
  Contributor.make(:login => login, :name => name) unless Contributor.find_by_login(login)
end

Given /^there are no contributors$/ do
  Contributor.delete_all
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)"$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => contributor, :commits => 46).id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12
  }
  contributor.save
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)" which is owned by ([^\"]*)$/ do |name, project, owner|
  contributor = Contributor.find_by_name(name)
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => Contributor.make(:name => owner)).id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12
  }
  contributor.save
end
