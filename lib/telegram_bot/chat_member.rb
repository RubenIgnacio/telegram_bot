module TelegramBot
  class ChatMember
    include Virtus.model

    CREATOR = "creator"
    ADMINISTRATOR = "administrator"
    MEMBER = "member"
    RESTRICTED = "restricted"
    LEFT = "left"
    KICKED = "kicked"
    STATUS_TYPES = [CREATOR, ADMINISTRATOR, MEMBER, RESTRICTED, LEFT, KICKED]

    attribute :user, User
    attribute :status, String
    attribute :until_date, DateTime
    attribute :can_be_edited, Boolean
    attribute :can_change_info, Boolean
    attribute :can_post_messages, Boolean
    attribute :can_edit_messages, Boolean
    attribute :can_delete_messages, Boolean
    attribute :can_invite_users, Boolean
    attribute :can_restrict_members, Boolean
    attribute :can_pin_messages, Boolean
    attribute :can_promote_members, Boolean
    attribute :is_member, Boolean
    attribute :can_send_messages, Boolean
    attribute :can_send_media_messages, Boolean
    attribute :can_send_other_messages, Boolean
    attribute :can_add_web_page_previews, Boolean

    def status_is?(member_status)
      status == member_status
    end

    STATUS_TYPES.each do |member_status|
      class_eval <<-DEF, __FILE__, __LINE__ + 1
        def status_is_#{member_status}?
          status_is?("#{member_status}")
        end
      DEF
    end
  end
end