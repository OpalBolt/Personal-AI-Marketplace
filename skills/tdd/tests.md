# Good and Bad Tests

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

```python
# GOOD: tests observable behavior
def test_user_can_checkout_with_valid_cart():
    cart = create_cart()
    cart.add(product)
    result = checkout(cart, payment_method)
    assert result.status == "confirmed"
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```python
# BAD: tests implementation details
def test_checkout_calls_payment_service_process(mocker):
    mock_process = mocker.patch("checkout.payment_service.process")
    checkout(cart, payment)
    mock_process.assert_called_with(cart.total)
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```python
# BAD: bypasses interface to verify
def test_create_user_saves_to_database(db):
    create_user(name="Alice")
    row = db.query("SELECT * FROM users WHERE name = ?", ["Alice"])
    assert row is not None

# GOOD: verifies through interface
def test_create_user_makes_user_retrievable():
    user = create_user(name="Alice")
    retrieved = get_user(user.id)
    assert retrieved.name == "Alice"
```

**Tautological tests**: Expected value restates the implementation, so the test passes by construction.

```python
# BAD: expected value is recomputed the way the code computes it
def test_calculate_total_sums_line_items():
    items = [{"price": 10}, {"price": 5}]
    expected = sum(item["price"] for item in items)
    assert calculate_total(items) == expected

# GOOD: expected value is an independent, known literal
def test_calculate_total_sums_line_items():
    assert calculate_total([{"price": 10}, {"price": 5}]) == 15
```

## Seam vocabulary

For deciding where seams belong and what they should expose:

- **Module** — anything with an interface and an implementation: a function, class, package, or slice.
- **Interface** — everything a caller must know to use the module correctly: types, invariants, ordering constraints, error modes. Not just the type signature.
- **Seam** — where a module's interface lives; the place behaviour can vary without editing call sites (Michael Feathers).
- **Adapter** — a concrete thing that satisfies an interface at a seam. One adapter means a hypothetical seam; two means a real one.
- **Depth** — behaviour per unit of interface. A deep module hides a lot behind a small interface; a shallow one is nearly as complex inside as out.
- **Leverage / locality** — what depth buys: callers learn less to do more; changes, bugs, and knowledge concentrate in one place.
- **The interface is the test surface.** Callers and tests cross the same seam — wanting to test past the interface is a design smell, not a mocking problem.

Vocabulary adapted from [mattpocock/skills](https://github.com/mattpocock/skills) — codebase-design.
