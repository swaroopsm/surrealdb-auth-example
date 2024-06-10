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
DEFINE SCOPE oauth SESSION 7d
  SIGNUP {
    BEGIN;
      $user = (SELECT * FROM only user where email = $email LIMIT 1) ||
              (INSERT INTO user (name, email) VALUES ($name, $email));

      $account = (SELECT * FROM only account  where provider = $provider and sub = $sub LIMIT 1) ||
                 (INSERT INTO account (provider, sub, meta) VALUES ($provider, $sub, $meta));

      $accountConnection = SELECT * FROM authenticated
                            WHERE in.id = $user.id
                            AND out.id=$account.id;

      IF !$accountConnection {
        RELATE $user->authenticated->$account;
      };

      RETURN $user;
    COMMIT;
   };
