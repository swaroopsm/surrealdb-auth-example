DEFINE FUNCTION fn::github__oauthUrl() {
    LET $params = array::join([
      array::join(['client_id', $GITHUB_CLIENT_ID], '='),
      array::join(['redirect_uri', $GITHUB_CALLBACK_URL], '='),
    ], '&');

    RETURN array::join([
      'https://github.com/login/oauth/authorize',
      $params
    ], '?');
};

DEFINE FUNCTION fn::github__oauthAuthorize($code: string) {
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
    email: $user.email,
    meta: {
      login: $user.login,
      url: $user.url,
      avatarUrl: $user.avatar_url,
      gravatarId: $user.gravatar_id,
    }
  }
};