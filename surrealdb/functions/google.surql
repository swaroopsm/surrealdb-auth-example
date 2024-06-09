DEFINE FUNCTION fn::google__oauthUrl() {
    LET $params = array::join([
      array::join(['client_id', $GOOGLE_CLIENT_ID], '='),
      array::join(['access_type', 'offline'], '='),
      array::join(['redirect_uri', $GOOGLE_CALLBACK_URL], '='),
      array::join(['response_type', 'code'], '='),
      array::join(['include_granted_scopes', 'true'], '='),
      array::join(['scope', 'https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile'], '='),
    ], '&');

    RETURN array::join([
      'https://accounts.google.com/o/oauth2/v2/auth',
      $params
    ], '?');
};

DEFINE FUNCTION fn::google__oauthAuthorize($code: string) {
  LET $authorizationUrl = 'https://oauth2.googleapis.com/token';

  LET $response = http::post($authorizationUrl, {
    'code': $code,
    client_id: $GOOGLE_CLIENT_ID,
    client_secret: $GOOGLE_CLIENT_SECRET,
    grant_type: 'authorization_code',
    redirect_uri: 'http://localhost:5173/api/oauth/google/callback'
  }, {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  });

  LET $accessToken = $response.access_token;

  -- Fetch Google user details for creation
  LET $user = http::get('https://www.googleapis.com/oauth2/v1/userinfo', {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': string::concat('Bearer ', $accessToken)
  });

  RETURN {
    id: $user.id,
    name: $user.name,
    email: $user.email,
    meta: {
      verifiedEmail: $user.verified_email,
      avatarUrl: $user.picture,
    }
  }
};