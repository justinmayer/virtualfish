from setuptools import setup, find_packages

setup(
    name='virtualfish',
    description='A virtualenv wrapper for the Fish shell',
    author='Adam Brenecki',
    author_email='adam@brenecki.id.au',
    url='https://github.com/adambrenecki/virtualfish',
    packages=find_packages(),
    include_package_data=True,
    setup_requires=[
        'setuptools_scm>=1.11.1',
    ],
    use_scm_version=True,
    install_requires=[
        'pkgconfig>=1.2.2,<2',
        'psutil>=5.2.2,<6',
        'virtualenv',
        'xdg>=1.0.5,<2',
    ],
    extras_require={
        'dev': [
            'pytest>=3.1.3,<3.2',
        ],
    },
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
        'Topic :: System :: Shells',
    ]
)
