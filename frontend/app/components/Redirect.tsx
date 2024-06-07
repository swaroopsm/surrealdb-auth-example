import { useNavigate } from "@remix-run/react";
import { useEffect } from "react";

interface Props {
  to: string;
}

export function Redirect({ to }: Props) {
  const navigate = useNavigate();

  useEffect(() => {
    navigate(to);
  }, [navigate, to]);

  return null;
}
