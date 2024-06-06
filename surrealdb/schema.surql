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
DEFINE INDEX provider_sub_unique ON account FIELDS provider, sub UNIQUE;
DEFINE FIELD meta ON TABLE account FLEXIBLE TYPE option<object>;

-- Graph Edge user <-> account
DEFINE FIELD in ON TABLE authenticated TYPE record<user>;
DEFINE FIELD out ON TABLE authenticated TYPE record<account>;
DEFINE TABLE authenticated SCHEMAFULL PERMISSIONS
  FOR SELECT WHERE in.id = $auth.id;

-- Events
-- Doesn't seems to be triggering this event :'(
DEFINE EVENT authenticate_deleted ON TABLE authenticated WHEN $event = "DELETE" THEN { 
	-- DELETE account;
	DELETE account WHERE id = $before.out.id;
};