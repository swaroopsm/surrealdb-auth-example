USE NS surrealdb_auth_example DB default;

-- Table: user
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

-- Table: account
DEFINE TABLE account SCHEMAFULL
	PERMISSIONS
		FOR create, update, delete NONE 
    FOR select WHERE <-authenticated.in CONTAINS $auth.id;
DEFINE FIELD provider ON account TYPE string;
DEFINE FIELD sub ON account TYPE string;
DEFINE INDEX provider_sub_unique ON user FIELDS provider, sub UNIQUE;

-- Graph Edge user <-> account
DEFINE FIELD in ON TABLE authenticated TYPE record<user>;
DEFINE FIELD out ON TABLE authenticated TYPE record<account>;
DEFINE TABLE authenticated SCHEMAFULL PERMISSIONS
  FOR SELECT WHERE in.id = $auth.id;

-- Local auth scope
DEFINE SCOPE credentials SESSION 7d
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


-- OAuth scope
DEFINE SCOPE IF NOT EXISTS oauth SESSION 7d
	SIGNUP {
		BEGIN;
			$user = (SELECT * FROM only user where email = $email LIMIT 1) ||
							(INSERT INTO account (provider, sub) VALUES ($provider, $sub));

			$account = (SELECT * FROM only account  where provider = $provider and sub = $sub LIMIT 1) ||
								 (INSERT INTO user (name, email) VALUES ($name, $email));

			$accountConnection = SELECT id FROM account
														WHERE <-authenticated[WHERE in.id = $user.id
															AND out.provider=$provider and out.sub = $sub];

			IF $accountConnection IS NONE {
				RELATE $user->authenticated->$account;
			};

			RETURN $user;
		COMMIT;
	 };