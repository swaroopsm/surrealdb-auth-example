export interface Me {
  name: string;
  email: string;
  maskedEmail: string;
  initials: string;
  avatar?: string | null;
  connected_accounts: {
    provider: string;
    url: string;
    avatar: string;
    meta: any;
  }[];
}

export interface OutletContext {
  me?: Me;
}
