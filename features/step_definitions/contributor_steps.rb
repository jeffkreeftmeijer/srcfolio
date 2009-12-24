Given /^a contributor exists with a login of "([^\"]*)" and a name of "([^\"]*)"$/ do |login, name|
  Contributor.make(:login => login, :name => name)
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)" which is owned by ([^\"]*)$/ do |contributor, project, owner|
  contributor = Contributor.find_by_name(contributor)
  owner = Contributor.make(:name => owner)
  project = Project.make(:name => project)
  project.owner = owner
  project.save
  contributor.contributions << {:project => project.id}
  contributor.save
end

Given /^there are no contributors$/ do
  Contributor.delete_all
end

Given /^([^\"]*) has ([^\"]*) commits of ([^\"]*) on ([^\"]*)$/ do |contributor, commits, total_commits, project|
   contributor = Contributor.find_by_name(contributor)
   project = Project.find_by_name(project)
   project.commits = total_commits.to_i
   project.save   
   contributor.contributions.first.merge!({:project => project.id, :commits => commits.to_i})
   contributor.save
end

Given /^([^\"]*) started working on ([^\"]*) on ([^\"]*)$/ do |contributor, project, started|
  contributor = Contributor.find_by_name(contributor)
  project = Project.find_by_name(project)
  contributor.contributions.first.merge!({:started_at => started})
  contributor.save
end
