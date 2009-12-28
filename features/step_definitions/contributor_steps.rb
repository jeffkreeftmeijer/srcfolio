Given /^a contributor exists with a login of "([^\"]*)"$/ do |login|
  Contributor.make(:login => login, :name => nil) unless Contributor.find_by_login(login)
end

Given /^a contributor exists with a name of "([^\"]*)"$/ do |name|
  Contributor.make(:login => '', :name => name) unless Contributor.find_by_name(name)
end

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

Given /^([^\"]*) owns a project named "([^\"]*)"$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => contributor).id,
    :owner => true
  }
  contributor.save
end

Given /^([^\"]*) is in the team of a project named "([^\"]*)"$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project).id,
    :member => true
  }
  contributor.save
end

Given /^([^\"]*) owns a project named "([^\"]*)" and has contributed to that project$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  project = Project.make(:name => project, :owner => contributor)
  contributor.contributions << {
    :project => project.id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12,
    :owner => true
  }
  contributor.save
end

Given /^([^\"]*) is in the team of a project named "([^\"]*)" and has contributed to that project$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  project = Project.make(:name => project)
  contributor.contributions << {
    :project => project.id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12,
    :member => true
  }
  contributor.save
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)", which is invisible$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project, :visible => false).id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12
  }
  contributor.save
end

Given /^([^\"]*) owns a project named "([^\"]*)", which is invisible$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => contributor, :visible => false).id,
    :owner => true
  }
  contributor.save
end

Given /^([^\"]*) is in the team of a project named "([^\"]*)", which is invisible$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project, :visible => false).id,
    :member => true
  }
  contributor.save
end

Then /^I should see ([^\"]*)'s gravatar$/ do |name|
  contributor = Contributor.find_by_name(name)
  response.body.should include("http://www.gravatar.com/avatar/012a6a06cd312fbc0be8b3f28c4ef880.jpg")
end

