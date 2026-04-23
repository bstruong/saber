# Performance Guidelines

## N+1 Queries

### Filtering — use `joins`

Scopes that filter via associations must use `joins`, not load records into Ruby and iterate.

```ruby
# Good — one SQL query
scope :with_upcoming_events, -> {
  joins(:important_dates).where(...).distinct
}

# Bad — loads all records, then filters in Ruby
Person.all.select { |p| p.important_dates.any? { ... } }
```

### Serialization — use `includes` or `eager_load`

When a controller renders JSON that includes association data, eager-load those associations on the query. Don't wait for a production complaint.

```ruby
# Good
persons = Person.active.includes(:contact_methods, :important_dates)

# Bad — triggers one query per person for each association
persons = Person.active
render json: persons.map { |p| { ...p.contact_methods... } }
```

### Rule of thumb

- `joins` → filtering (WHERE clause touches association, association not serialized)
- `includes` → serialization (association data goes into the response)
- `eager_load` → when you need `includes` but also need to filter on the association in the same query
