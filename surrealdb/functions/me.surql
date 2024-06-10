DEFINE FUNCTION fn::whoami() {
  IF !$auth {
    THROW 'err::UNAUTHORIZED';
  };

  $whoami = SELECT *, ->authenticated.out.* as connected_accounts FROM ONLY $auth.id;

  IF !$whoami.id {
    THROW 'err::UNAUTHORIZED';
  };

  RETURN function ($whoami) {
    const [whoami] = arguments;
    const avatar = whoami.connected_accounts?.map?.(account => {
       {return account?.meta?.avatarUrl}
    }).filter(Boolean);     
    const [username, domain] = whoami.email.split('@');

    return {
      ...whoami,
      initials: whoami.name.split(' ').filter((_, index) => index <= 1).map(word => word[0]).join(''),
      connected_accounts: whoami.connected_accounts?.map?.(account => ({
        ...account,
        url: account.provider === 'github' ? `https://www.github.com/${account?.meta?.login}` : '',

      })) || [],
      avatar: avatar?.[0] || null,
      maskedEmail: [username.slice(0, 3), "**********", domain].join('@'),
    };
  };
};
