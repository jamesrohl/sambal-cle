require 'rspec'
require "#{File.dirname(__FILE__)}/../lib/sambal-cle"
require 'yaml'

describe 'Duplicate Site' do

  include StringFactory
  include Navigation
  include Foundry

  before :all do

    # Get the test configuration data
    @config = YAML.load_file('config.yml')
    @directory = YAML.load_file('directory.yml')
    @sakai = SambalCLE.new(@config['browser'], @config['url'])
    @browser = @sakai.browser

    @instructor = make UserObject, :id=>@directory['person3']['id'], :password=>@directory['person3']['password'],
                       :first_name=>@directory['person3']['firstname'], :last_name=>@directory['person3']['lastname'],
                       :type=>'Instructor'
    @file_path = @config['data_directory']
    @source_site_string = 'Links to various items in this site:'

    # Log in to Sakai
    @instructor.login

    @site1 = create CourseSiteObject

    @source_site_string << "<br />\n<br />\nSite ID: #{@site1.id}<br />\n<br />\n"

    @assignment = create AssignmentObject, :site=>@site1.name, :instructions=>@source_site_string
    @assignment.get_info
    @assignment.get_direct_url

    @source_site_string << "Assignment...<br />\nID:(n) #{@assignment.id}<br />\n"
    @source_site_string << "Link (made 'by hand'): <a href=\"#{@assignment.link}\">#{@assignment.title}</a><br />\n"
    @source_site_string << "<em>Direct</em> URL from Link Tool:(y) <a href=\"#{@assignment.direct_url}\">#{@assignment.title}</a><br />\n<br />\n#{@assignment.direct_url}<br />\n<br />\n"

    @announcement = create AnnouncementObject, :site=>@site1.name, :body=>@source_site_string

    @source_site_string << "<br />\nAnnouncement link: <a href=\"#{@announcement.link}\">#{@announcement.title}</a><br />\n"

    @file = create FileObject, :site=>@site1.name, :name=>"flower02.jpg", :source_path=>@file_path+"images/"

    @source_site_string << %|<br />\nUploaded file: <a href="#{@file.href}">#{@file.name}</a><br />\n<img width="203" height="196" src="#{$base_url}/access/content/group/#{@site1.id}/#{@file.name}" alt="" /><br /><br />|

    @htmlpage = create HTMLPageObject, :site=>@site1.name, :folder=>"#{@site1.name} Resources", :html=>@source_site_string

    @source_site_string << "<br />\nHTML Page: <a href=\"#{@htmlpage.url}\">#{@htmlpage.name}</a><br />\n"

    @folder = create FolderObject, :site=>@site1.name, :parent_folder=>"#{@site1.name} Resources"

    @nestedhtmlpage = create HTMLPageObject, :site=>@site1.name, :folder=>@folder.name, :html=>@source_site_string

    @source_site_string << "<br />\nNested HTML Page: <a href=\"#{@nestedhtmlpage.url}\">#{@nestedhtmlpage.name}</a><br />\n"

    @web_content1 = create WebContentObject, :title=>@htmlpage.name, :source=>@htmlpage.url, :site=>@htmlpage.site

    @web_content2 = create WebContentObject, :title=>@nestedhtmlpage.name, :source=>@nestedhtmlpage.url, :site=>@nestedhtmlpage.site

    @module = create ModuleObject, :site=>@site1.name

    @source_site_string << "<br />\nModule: <a href=\"#{@module.href}\">#{@module.name}</a><br />\n"

    @section1 = create ContentSectionObject, :site=>@site1.name, :module=>@module.title, :content_type=>"Compose content with editor",
                     :editor_content=>@source_site_string

    @source_site_string << "<br />\nSection 1: <a href=\"#{@section1.href}\">#{@section1.name}</a><br />\n"

    @section2 = create ContentSectionObject, :site=>@site1.name, :module=>@module.title, :content_type=>"Upload or link to a file",
                     :file_name=>"flower01.jpg", :file_path=>@file_path+"images/"

    @source_site_string << "<br />Section 2: <a href=\"#{@section2.href}\">#{@section2.name}</a><br />"

    @section3 = create ContentSectionObject, :site=>@site1.name, :module=>@module.title, :content_type=>"Link to new or existing URL resource on server",
                     :url=>@htmlpage.url, :url_title=>@htmlpage.name

    @section4 = create ContentSectionObject, :site=>@site1.name, :module=>@module.title, :content_type=>"Upload or link to a file in Resources",
                     :file_name=>@nestedhtmlpage.name, :file_folder=>@nestedhtmlpage.folder

    @wiki = create WikiObject, :site=>@site1.name, :content=>"{image:worksite:/#{@file.name}}\n\n{worksiteinfo}\n\n{sakai-sections}"

    @source_site_string << "<br />Wiki: <a href=\"#{@wiki.href}\">#{@wiki.title}</a><br />"

    @syllabus = create SyllabusObject, :content=>@source_site_string, :site=>@site1.name

    @forum = create ForumObject, :site=>@site1.name, :short_description=>random_alphanums, :description=>@source_site_string
    @forum.get_direct_link

    @source_site_string << "<br />\nForum link: <a href=\"#{@forum.direct_link}\">#{@forum.title}</a><br />\n"

    @topic = create TopicObject, :site=>@site1.name, :forum=>@forum.title, :description=>@source_site_string
    @topic.get_direct_link

    @source_site_string << "<br />\nTopic link: <a href=\"#{@topic.direct_link}\">#{@topic.title}</a><br />\n"

    @event = create EventObject, :site=>@site1.name, :message=>@source_site_string

    @forum.edit :description=>@source_site_string

    @topic.edit :description=>@source_site_string

    @assignment.edit :instructions=>@source_site_string

    @announcement.edit :body=>@source_site_string

    @htmlpage.edit_content @source_site_string

    @nestedhtmlpage.edit_content @source_site_string

    @section1.edit :editor_content=>@source_site_string

    @assessment = create AssessmentObject, :site=>@site1.name
    @assessment.add_question :type=>'Short Answer/Essay', :rich_text=>true, :text=>%|<img width="203" height="196" src="#{$base_url}/access/content/group/#{@site1.id}/#{@file.name}" alt="" />|
    @assessment.publish

    @site2 = @site1.duplicate

    @new_assignment = make AssignmentObject, :site=>@site2.name, :status=>'Draft', :title=>@assignment.title
    @new_assignment.get_info
    @new_assignment.get_direct_url

  end

  after :all do
    # Close the browser window
    @browser.close
  end

  def check_this_stuff(thing)
    thing.should match /Site ID: #{@site2.id}/
    thing.should match /\(y\)\s+\[?<a href..#{@new_assignment.direct_url}/
    thing.should match /<img.+#{@site2.id}\/#{@file.name}/
    thing.should_not match /Announcement link:.+#{@announcement.id}.+#{@announcement.title}/
    thing.should match /Uploaded file:.+#{@site2.id}.+#{@file.name}/
    thing.should match /#{@site2.id}\/#{@htmlpage.name}/
    thing.should match /#{@site2.id}\/#{@folder.name}\/#{@nestedhtmlpage.name}/
    thing.should match /Wiki:.+#{@site2.id}.+#{@wiki.name}/
    thing.should_not match /Forum link:.+#{@forum.direct_link}.+#{@forum.title}/
    thing.should_not match /Topic link:.+#{@topic.direct_link}.+#{@topic.title}/

    # These are not expected to work:
    #puts "Assignment ID updated? " + (thing[/ID:\(n\) #{@new_assignment.id}/]==nil ? "no" : "yes")
    #puts "Assignment Link updated? " + (thing[/hand.\): <a href.+#{@new_assignment.link}.+doView_assignment/]==nil ? "no" : "yes")
    #puts "Entity picker Assignment URL updated? " + (thing[/\(x\) <a href.+#{@new_assignment.url}.+doView_submission/]==nil ? "no" : "yes")
    #puts "Assignment Portal Link updated? " + (thing[/\(z\) <a href..#{@new_assignment.portal_url}/]==nil ? "no" : "yes")
    #puts "Module Link updated? " + (thing[/Module:.+#{@site2.id}.+#{@module.name}/]==nil ? "no" : "yes")
    #puts "Section 1 Link updated? " + (thing[/Section 1:.+#{@site2.id}.+#{@section1.name}/]==nil ? "no" : "yes")
    #puts "Section 2 Link updated? " + (thing[/Section 2:.+#{@site2.id}.+#{@section2.name}/]==nil ? "no" : "yes")
    #puts "Wiki link updated? " + (thing[/#{@site2.id}/]==nil ? "no" : "yes")
    #puts "Syllabus Link updated? " + (thing[/Syllabus: #{@site2.id}/]==nil ? "no" : "yes")
  end

  it 'duplicates Assignments correctly' do
    check_this_stuff(@new_assignment.instructions)
  end

  it 'duplicates Web Content pages correctly' do
    open_my_site_by_name @site2.name unless @browser.title=~/#{@site2.name}/
    @browser.link(:text=>@web_content1.title, :href=>/#{@site2.id}/).should be_present
    @browser.link(:text=>@web_content2.title, :href=>/#{@site2.id}/).should be_present

  end

  it 'duplicates Announcements correctly' do
    @new_announcement = make AnnouncementObject, :site=>@site2.name, :title=>"Draft - #{@announcement.title}"
    open_my_site_by_name @new_announcement.site
    announcements
    on(Announcements).edit @new_announcement.title
    on AddEditAnnouncements do |edit|
      edit.source
      check_this_stuff edit.source_field.value
    end
  end

  it 'duplicates Forums correctly' do
    @new_forum = make ForumObject, :site=>@site2.name, :title=>@forum.title
    @new_forum.view

    check_this_stuff(@new_forum.description_html)
  end

  it 'duplicates Topics correctly' do
    @new_topic = make TopicObject, :site=>@site2.name, :forum=>@forum.title, :title=>@topic.title
    @new_topic.view
    check_this_stuff(@new_topic.description_html)
  end

  it 'duplicates Lessons correctly' do
    lessons
    on Lessons do |lessons|
      lessons.lessons_list.should include @module.title
      lessons.sections_list(@module.title).should include @section1.title
      lessons.sections_list(@module.title).should include @section2.title
      lessons.sections_list(@module.title).should include @section3.title
      lessons.sections_list(@module.title).should include @section4.title
      lessons.open_section @section1.title
    end
    on AddEditContentSection do |section|
      section.source
      @text = section.source_field.value
    end

    check_this_stuff @text
  end

  it 'duplicates Syllabi correctly' do
    @new_syllabus = make SyllabusObject, :site=>@site2.name, :title=>@syllabus.title
    @new_syllabus.get_properties

    check_this_stuff @new_syllabus.content
  end

  it 'duplicates Wikis correctly' do
    @new_wiki = make WikiObject, :site=>@site2.name, :title=>@wiki.title
    @new_wiki.get_content

    @new_wiki.content.should == @wiki.content
  end

  it 'duplicates Resources correctly' do
    resources
    on Resources do |resources|
      resources.folder_names.should include @folder.name
      resources.file_names.should include @file.name
    end
  end

  it 'duplicates Events correctly' do
    @new_event = make EventObject, :title=>@event.title, :site=>@site2.name
    @new_event.view

    check_this_stuff @new_event.message_html
  end

  it 'duplicates Assessments correctly' do
    @new_assessment = make AssessmentObject, :title=>@assessment.title, :site=>@site2.name
    @new_assessment.questions=@assessment.questions
    assessments
    on AssessmentsList do |list|
      list.pending_assessment_titles.should include @new_assessment.title
      list.edit @new_assessment.title
    end
    on EditAssessment do |edit|
      edit.edit_question(1,1)
    end
    on ShortAnswer do |q|
      q.source
      q.source_field.value.should==%|<img width="203" height="196" alt="" src="#{$base_url}/access/content/group/#{@site2.id}/#{@file.name}" />|
    end
  end

end