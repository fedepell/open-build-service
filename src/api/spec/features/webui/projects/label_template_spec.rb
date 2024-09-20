require 'browser_helper'

RSpec.describe 'LabelTemplates', :js, :vcr do
  let!(:user) { create(:confirmed_user, :with_home, login: 'Jane') }
  let(:project) { user.home_project }

  before do
    Flipper.enable(:labels)

    login user
  end

  context 'when having no label templates' do
    it 'creates a label template' do
      visit project_label_templates_path(project)

      click_on('Create Label Template')
      fill_in('Name', with: 'A label template')
      click_on('Create')

      expect(LabelTemplate.last.name).to eql('A label template')
    end
  end

  context 'when having an already existing label template' do
    let!(:label_template) { create(:label_template, project: project) }
    let(:another_project) { create(:project, maintainer: user) }

    it 'updates an already existing label template' do
      visit project_label_templates_path(project)

      click_on('Edit')
      fill_in('Name', with: 'A label template updated')
      click_on('Update')

      expect(label_template.reload.name).to eql('A label template updated')
    end

    it 'deletes an already existing label template' do
      visit project_label_templates_path(project)

      accept_confirm { click_on('Delete') }
      expect(page).to have_text('Label template deleted successfully')
    end

    context 'copies label templates to another project' do
      before do
        visit project_label_templates_path(another_project)

        click_on('Copy from Another Project')
        fill_in('Source Project', with: project.name)
        click_on('Copy')
      end

      it 'copies all the label templates' do
        expect(page).to have_text(project.label_templates.first.name)
      end
    end
  end
end
