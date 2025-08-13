from models.models import User, Role, Organization, Document, Session, Signature

print("\n--- User CRUD Test ---")

existing_users = User.query(email="testUser@gmail.com")
if existing_users:
    user = existing_users[0]
    print("User already exists")
else:
    user = User(
        email="testUser@gmail.com",
        password="password1",
        tracking_id=10101,
        role_id=1,
        organization_id=1
    )
    user.save()
    print("User created successfully!")


# Update the user's password
user.password = "newpassword"
print("User updated")

if user:
    User.delete("user", user.user_id)
    print("User deleted")
else:
    print("User not found")


print("\n\n--- Role and Query Test ---")

# create roles

if not Role.query(role_id=1):
    admin = Role(role_id=1, title="admin", permissions="all")
    admin.save()

if not Role.query(role_id=2):
    verifier = Role(role_id=2, title="verifier", permissions="verify_only")
    verifier.save()

# filter test
roles = Role.query(title="admin")
for role in roles:
    print(f"Found role: {role.title}")


print("\n\n--- Join Test ---")

# recreate a user
if not User.query(email="testUser2@gmail.com"):
    user = User(email="testUser2@gmail.com", password="password2", tracking_id=20202, role_id=1, organization_id=1)
    user.save()

# join user and role
results = User.join(Role, on=("user.role_id", "role.role_id"))
for row in results:
    print(f"{row['email']} has role: {row['title']}")


print("\n\n--- Document Test ---")

doc = Document(title="SecurityPolicy", content="encrypted_words", upload_time="2025-07-27 10:22:07", organization_id=1)
doc.save()
print("Document inserted")


