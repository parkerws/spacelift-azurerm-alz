from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="azlz-cli",
    version="0.1.0",
    author="Your Organization",
    author_email="your-email@example.com",
    description="Azure Landing Zone Factory CLI for Spacelift",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/your-org/spacelift-azurerm-alz",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Build Tools",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.9",
    install_requires=[
        "click>=8.1.0",
        "pyyaml>=6.0",
        "jinja2>=3.1.0",
        "requests>=2.31.0",
        "python-dotenv>=1.0.0",
        "rich>=13.0.0",
        "tabulate>=0.9.0",
        "jsonschema>=4.0.0",
    ],
    entry_points={
        "console_scripts": [
            "azlz=azlz.cli:main",
        ],
    },
)
