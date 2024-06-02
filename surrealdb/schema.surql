USE NS surrealdb_auth_example DB default;

DEFINE TABLE user SCHEMAFULL
	PERMISSIONS
		FOR select, update, delete WHERE id = $auth.id
    FOR create NONE;

DEFINE FIELD name ON user TYPE string;
DEFINE FIELD email ON user TYPE string ASSERT string::is::email($value);
DEFINE FIELD password ON user TYPE option<string>
        PERMISSIONS
          FOR select NONE;
DEFINE FIELD preferred_languages ON user TYPE option<array> ASSERT $value ALLINSIDE ["en", "de", "es", "fr", "ru"] VALUE [];

DEFINE INDEX email ON user FIELDS email UNIQUE;


DEFINE SCOPE IF NOT EXISTS user SESSION 7d
	SIGNIN (
		SELECT * FROM user WHERE email = $email AND crypto::argon2::compare(password, $password)
	)
	SIGNUP (
		CREATE user CONTENT {
			name: $name,
			email: $email,
			password: crypto::argon2::generate($password)
		}
	);

DEFINE SCOPE IF NOT EXISTS  user_third_party SESSION 7d;

DEFINE TOKEN github ON SCOPE user TYPE HS256 VALUE "my_gh_token";
