"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { label: "Home", href: "/" },
  { label: "Companions", href: "/companions" },
  // Was 'my-journey' with no leading slash, which resolved relative to whatever
  // page you happened to be on — from /companions/abc it went looking for
  // /companions/my-journey and 404'd.
  { label: "My Journey", href: "/my-journey" },
];

const NavItems = () => {
  const pathname = usePathname();

  return (
    <nav className="flex items-center gap-1">
      {navItems.map(({ label, href }) => (
        <Link
          href={href}
          key={label}
          className="nav-link"
          data-active={pathname === href ? "true" : undefined}
        >
          {label}
        </Link>
      ))}
    </nav>
  );
};

export default NavItems;
