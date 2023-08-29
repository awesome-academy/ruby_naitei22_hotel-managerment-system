class AddPasswordDigestToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :password_digest, :string
    # password_digest là một chuỗi hash tao ra boi bcrypt co format:
    # $2<a/b/x/y>$[cost]$[22 character salt][31 character hash]
    # vi du: password la 123456789 -> cost = 12 (do dai chuoi password)
    # 
    # $2a$12$R9h/cIPz0gi.URNNX3kh2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUW
    # \__/\/ \____________________/\_____________________________/
    # Alg Cost      Salt                        Hash
    # 
    # $2a$: thuat toan hash (bcrypt)
    # 12: Input cost
    # R9h/cIPz0gi.URNNX3kh2O: gia tri salt ngau nhien
    # PST9/PgBkqquzi.Ss7KIUgO2t0jWMUW: 23 bytes dau tien trong 24 bytes sau khi hash
  end
end
