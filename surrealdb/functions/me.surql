DEFINE FUNCTION fn::whoami() {
  IF !$auth {
    THROW 'err::UNAUTHORIZED';
  };

  $whoami = SELECT *, ->authenticated.out.* as connected_accounts FROM ONLY $auth.id;

  IF !$whoami.id {
    THROW 'err::UNAUTHORIZED';
  };

  RETURN $whoami;
};