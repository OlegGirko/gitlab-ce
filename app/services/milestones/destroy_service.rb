module Milestones
  class DestroyService < Milestones::BaseService
    def execute(milestone)

      Milestone.transaction do
        update_params = { milestone: nil }
        milestone.issues.each do |issue|
          Issues::UpdateService.new(project, current_user, update_params).execute(issue)
        end

        event_service.destroy_milestone(milestone, current_user)

        Event.for_milestone_id(milestone.id).each do |event|
          event.target_id = nil
          event.save
        end

        milestone.destroy
      end
    end
  end
end
