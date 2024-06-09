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
    LET $params = {
    code: $code,
    client_id: $GOOGLE_CLIENT_ID,
    client_secret: $GOOGLE_CLIENT_SECRET,
    grant_type: 'authorization_code',
    redirect_uri: $GOOGLE_CALLBACK_URL
    };

  // For some reason http::post doens't work for `application/x-www-form-urlencoded` and hence using the fetch API
  LET $oauthFn = function($authorizationUrl, $params) {
    const [authorizationUrl, params] = arguments;
    const response = await fetch(authorizationUrl, {
      method: 'POST',
      body: Object.keys(params).map(key => `${key}=${encodeURIComponent(params[key])}`).join('&'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    const data = await response.json();

    return data;
  };

  LET $data = SELECT * FROM ONLY $oauthFn;

  -- Fetch Google user details for creation
  LET $user = http::get('https://www.googleapis.com/oauth2/v1/userinfo', {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': string::concat('Bearer ', $data.access_token)
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