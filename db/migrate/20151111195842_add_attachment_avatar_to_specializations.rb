class AddAttachmentAvatarToSpecializations < ActiveRecord::Migration
  def self.up
    change_table :specializations do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :specializations, :avatar
  end
end
