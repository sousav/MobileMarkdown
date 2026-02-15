# MobileMarkdown Sample Document

This is a comprehensive test file that exercises **all supported markdown syntax**.

---

## Headings

### Third Level

#### Fourth Level

##### Fifth Level

###### Sixth Level

---

## Text Formatting

This is **bold text** and this is *italic text*.

This is ***bold and italic*** text combined.

This is ~~strikethrough~~ text.

This is `inline code` within a paragraph.

---

## Links

Visit [Flutter](https://flutter.dev) for more information.

Check out [Dart language](https://dart.dev "Dart website").

---

## Blockquotes

> This is a blockquote. It can span multiple lines and should have a
> styled left border with an accent color.
>
> > Nested blockquotes are also supported.

---

## Ordered Lists

1. First item
2. Second item
3. Third item
   1. Nested first
   2. Nested second
4. Fourth item

---

## Unordered Lists

- Apple
- Banana
- Cherry
  - Dark cherry
  - Light cherry
    - Extra nested
- Date

---

## Task Lists (Checkboxes)

- [x] Completed task
- [ ] Incomplete task
- [x] Another completed task
- [ ] One more to do

---

## Code Blocks

### Python

```python
def fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

for i in range(10):
    print(f"F({i}) = {fibonacci(i)}")
```

### JavaScript

```javascript
const fetchData = async (url) => {
  try {
    const response = await fetch(url);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed to fetch:', error);
    throw error;
  }
};
```

### Dart

```dart
class MarkdownViewer extends StatefulWidget {
  final String content;
  
  const MarkdownViewer({super.key, required this.content});
  
  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}
```

---

## Tables

| Feature | Android | iOS |
|---------|---------|-----|
| File picker | Yes | Yes |
| Share sheet | Yes | Yes |
| Intent handling | Yes | Yes |
| Dark mode | Yes | Yes |

### Wider Table

| Language | Typing | Compiled | Use Case | Performance | Ecosystem |
|----------|--------|----------|----------|-------------|-----------|
| Dart | Strong | AOT/JIT | Mobile, Web | Excellent | Growing |
| Python | Dynamic | No | AI/ML, Scripts | Good | Mature |
| JavaScript | Dynamic | JIT | Web, Server | Good | Massive |
| Rust | Strong | AOT | Systems | Best | Growing |

---

## Images

![Flutter Logo](https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd3cf16282.png)

---

## Horizontal Rules

Above the rule.

---

Below the rule.

***

Another rule style.

___

Yet another.

---

## Nested Lists with Mixed Content

1. **First major point**
   - Supporting detail A
   - Supporting detail B with `code`
   - Supporting detail C
2. **Second major point**
   - Detail with [a link](https://example.com)
   - Detail with *emphasis*
3. **Third major point**
   1. Sub-numbered one
   2. Sub-numbered two

---

## Long Paragraph

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

---

*End of sample document*
