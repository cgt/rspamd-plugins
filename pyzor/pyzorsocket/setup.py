from setuptools import setup

def readme():
    with open("README.md") as f:
        return f.read()

setup(
    name="pyzorsocket",
    version="0.1",
    license="MIT",

    author="Christoffer G. Thomsen",
    author_email="chris@cgt.name",

    url = "https://github.com/cgt/rspamd-plugins/tree/master/pyzor/pyzorsocket",
    description="Expose pyzor on a socket",
    long_description=readme(),

    py_modules=["pyzorsocket"],
    entry_points={
        "console_scripts": [
            "pyzorsocket=pyzorsocket:main",
        ],
    },
    install_requires=[
        "pyzor>=1.0.0",
    ],

    classifiers=[
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3 :: Only",
    ],
    keywords="pyzor spam",
)
