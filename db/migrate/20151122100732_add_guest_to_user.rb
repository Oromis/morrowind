class AddGuestToUser < ActiveRecord::Migration
  def up
    execute 'UPDATE users SET role = role + 1;'
  end

  def down
    execute 'UPDATE users SET role = role - 1;'
  end
end
