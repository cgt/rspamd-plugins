from setuptools import setup

def readme():
    with open("README.md") as f:
        return f.read()

setup(
    name="pyzorsocket",
    version="0.1",
    license="Boost Software License 1.0",

    author="Christoffer G. Thomsen",
    author_email="chris@cgt.name",

    url = "https://github.com/cgt/pyzorsocket",
    description="expose pyzor on a socket",
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
        "License :: OSI Approved",
        "Programming Language :: Python :: 3 :: Only",
    ],
    keywords="pyzor spam",
)
