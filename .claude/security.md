# Security Guidelines

## SQL Injection

Always use ActiveRecord's parameterized query forms. Never interpolate user input or untrusted values directly into SQL strings.

**Safe patterns:**

```ruby
# Positional placeholder
where("ring = ?", params[:ring])

# Named bind
where("occurred_at > :since", since: 6.months.ago)

# Hash form (preferred when possible)
where(ring: params[:ring])
```

**Acceptable raw SQL** — only when every value in the string is a column name, SQL function, or Ruby-generated constant with no user input path:

```ruby
# OK — all values are Ruby-computed integers, not user input
where("(important_dates.month, important_dates.day) IN (#{placeholders})", *upcoming.flatten)

# OK — no values, just column names and SQL functions
where("last_connected_at IS NULL OR last_connected_at + ... < NOW()")
```

When writing raw SQL, add a comment confirming no user input touches the string so the next reader doesn't have to re-audit it.
