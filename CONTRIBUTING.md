# Contributing to QGIS Cloud Browser

Thank you for your interest in contributing! 🎉

## How to Contribute

### Reporting Bugs

1. Check existing issues first
2. Create a new issue with:
   - Clear title
   - Detailed description
   - Steps to reproduce
   - Expected vs actual behavior
   - System info (OS, Docker version)
   - Logs (if applicable)

### Suggesting Features

1. Check if feature already requested
2. Open a feature request issue
3. Describe:
   - The problem it solves
   - How it should work
   - Potential implementation

### Pull Requests

1. Fork the repository
2. Create a feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. Make your changes
   - Follow existing code style
   - Add comments where needed
   - Update documentation

4. Test thoroughly
   ```bash
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   ```

5. Commit with clear messages
   ```bash
   git commit -m "Add amazing feature"
   ```

6. Push and create PR
   ```bash
   git push origin feature/amazing-feature
   ```

### Code Style

- **Bash**: Follow Google Shell Style Guide
- **Dockerfile**: Multi-stage builds, minimal layers
- **Docker Compose**: Clear service names, comments
- **HTML/CSS**: Semantic, accessible, responsive

### Testing

Before submitting:

- [ ] Code builds without errors
- [ ] All containers start successfully
- [ ] QGIS loads in browser
- [ ] No broken links in docs
- [ ] Scripts are executable

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/qgis-cloud-browser.git
cd qgis-cloud-browser

# Create feature branch
git checkout -b feature/my-feature

# Make changes and test
docker compose up --build

# Commit and push
git add .
git commit -m "Description"
git push origin feature/my-feature
```

## Questions?

Feel free to:
- Open a discussion
- Ask in issues
- Email: marcobirkedahl@gmail.com

---

**Thank you for contributing!** ❤️