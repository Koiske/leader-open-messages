# name: leader-open-messages
# version: 1.0.0
# authors: buildthomas

enabled_site_setting :leader_open_messages_enabled

after_initialize do

    # Intercept guard checks for sending private messages
    module GuardianInterceptor
        def can_send_private_message?(target, notify_moderators: false)
            # Check if exception for Leader applies here
            if SiteSetting.leader_open_messages_enabled
                return true if target.is_a?(User) &&
                    # User is authenticated
                    authenticated? &&
                    # Have to be Leader (tl4)
                    @user.trust_level >= 4 &&
                    # PMs are enabled
                    (is_staff? || SiteSetting.enable_personal_messages || notify_moderators) &&
                    # Silenced users can only send PM to staff
                    (!is_silenced? || target.staff?)
            end
            # Exception did not take effect, pass on up the chain instead
            super(target, notify_moderators: notify_moderators)
        end
    end
    Guardian.send(:prepend, GuardianInterceptor)

    # Intercept post validation checks for private messages
    module PostCreatorInterceptor
        def skip_validations?
            # No validations if requirements are met
            return true if SiteSetting.leader_open_messages_enabled &&
                # Only for Leader (tl4)
                @user.trust_level >= 4 &&
                # Only for private messages
                @opts[:archetype] == Archetype.private_message
            # Pass up on the chain instead
            super
        end
    end
    PostCreator.send(:prepend, PostCreatorInterceptor)

end
