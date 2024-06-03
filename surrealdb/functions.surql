DEFINE FUNCTION fn::ensure_authenticated() {
  IF !$auth {
    THROW "UNAUTHORIZED";
  }
};

DEFINE FUNCTION fn::whoami() {
  IF !$auth {
    THROW 'UNAUTHORIZED';
  };

  RETURN SELECT * FROM ONLY $auth.id;
};

DEFINE FUNCTION fn::update_language_preferences($languages: array<string>) {
  RETURN UPDATE $auth.id SET preferred_languages=$languages;
};

DEFINE FUNCTION fn::getToken() {
  RETURN SELECT * FROM $token;
};

DEFINE FUNCTION fn::getOAuthUrl($provider: string) {

  IF ($provider == "github") {
    LET $params = array::join([
      array::join(['client_id', $GITHUB_CLIENT_ID], '='),
      array::join(['redirect_uri', $GITHUB_CALLBACK_URL], '='),
    ], '&');

    RETURN array::join([
      'https://github.com/login/oauth/authorize',
      $params
    ], '?');
  } ELSE {
    THROW 'Provider is not configured';
  }

};

DEFINE FUNCTION fn::authorizeGithub($code: string) {
  LET $authorizationUrl = 'https://github.com/login/oauth/access_token';

  LET $response = http::post($authorizationUrl, {
    'code': $code,
    client_id: $GITHUB_CLIENT_ID,
    client_secret: $GITHUB_CLIENT_SECRET
  }, {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  });

  LET $accessToken = $response.access_token;

  -- Fetch GH user details for creation
  LET $user = http::get('https://api.github.com/user', {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': string::concat('Bearer ', $accessToken)
  });

  RETURN {
    id: $user.id,
    name: $user.name,
    email: $user.email
  }
};

DEFINE FUNCTION fn::mayBeCreateUserAfterOAuth($name: string, $email: string) {
 LET $existingUser = SELECT id from only user WHERE email=$email LIMIT 1;

 RETURN IF $existingUser  THEN 
    RETURN $existingUser;
 ELSE  {
    RETURN CREATE ONLY user SET name = $name, email = $email RETURN id;
 }
 END
}
