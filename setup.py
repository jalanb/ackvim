import os
import setuptools


def package_files(directory):
    paths = []
    extensions = (".test", ".tests", ".yaml")
    for (path, directories, filenames) in os.walk(directory):
        for filename in filenames:
            extension = os.path.splitext(filename)[-1]
            if extension not in extensions:
                continue
            paths.append(os.path.join("..", path, filename))
    return paths


setuptools.setup(
    packages=setuptools.find_packages(),
    package_data={"": package_files("ackvim")},
    tests_require = [
        'coverage',
        'pytest',
        'pytest-cov',
        'tox',
    ]
)
