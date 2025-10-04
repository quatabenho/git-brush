from setuptools import setup

setup(
    name='git-brush',
    version='0.1.0',
    description='A tool to clean up your git repository',
    author='quatabenho',
    py_modules=['git_brush'],
    entry_points={
        'console_scripts': [
            'git-brush=git_brush:main',
        ],
    },
    python_requires='>=3.6',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Version Control :: Git',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
    ],
)
